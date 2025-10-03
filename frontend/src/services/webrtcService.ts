import socketService from './socketService';

export class WebRTCService {
  private peerConnections: Map<string, RTCPeerConnection> = new Map();
  private localStream: MediaStream | null = null;
  private screenStream: MediaStream | null = null;
  private mediaStreamCallbacks: Map<string, (stream: MediaStream, participantId: string) => void> = new Map();
  private remoteStreams: Map<string, MediaStream> = new Map();
  private isAudioEnabled = true;
  private isVideoEnabled = true;
  private isScreenSharing = false;

  constructor() {
    this.setupSocketListeners();
  }

  private setupSocketListeners(): void {
    socketService.onOffer(this.handleOffer.bind(this));
    socketService.onAnswer(this.handleAnswer.bind(this));
    socketService.onIceCandidate(this.handleIceCandidate.bind(this));
    socketService.onScreenShareOffer(this.handleScreenShareOffer.bind(this));
    socketService.onScreenShareAnswer(this.handleScreenShareAnswer.bind(this));
    socketService.onScreenShareIceCandidate(this.handleScreenShareIceCandidate.bind(this));
  }

  // Initialize local media (camera and microphone)
  async initializeLocalMedia(): Promise<MediaStream | null> {
    try {
      this.localStream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { ideal: 1280 },
          height: { ideal: 720 },
          frameRate: { ideal: 30 }
        },
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true
        }
      });
      
      console.log('✅ Local media initialized');
      console.log('📹 Video tracks:', this.localStream.getVideoTracks().length);
      console.log('🎤 Audio tracks:', this.localStream.getAudioTracks().length);
      return this.localStream;
    } catch (error) {
      console.error('❌ Failed to initialize local media:', error);
      throw error;
    }
  }

  // Create peer connection for a participant
  private createPeerConnection(participantId: string): RTCPeerConnection {
    const configuration: RTCConfiguration = {
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' },
        { urls: 'stun:stun1.l.google.com:19302' }
      ]
    };

    const peerConnection = new RTCPeerConnection(configuration);
    
    // Handle incoming stream
    peerConnection.ontrack = (event) => {
      console.log('📺 Received remote stream from', participantId);
      if (event.streams && event.streams[0]) {
        this.remoteStreams.set(participantId, event.streams[0]);
        const callback = this.mediaStreamCallbacks.get('remoteStream');
        if (callback) {
          callback(event.streams[0], participantId);
        }
      }
    };

    // Handle ICE candidates
    peerConnection.onicecandidate = (event) => {
      if (event.candidate) {
        console.log('🧊 Sending ICE candidate to', participantId);
        socketService.sendIceCandidate(event.candidate, participantId);
      }
    };

    // Handle connection state changes
    peerConnection.onconnectionstatechange = () => {
      console.log(`🔗 Connection state for ${participantId}:`, peerConnection.connectionState);
    };

    // Handle ICE connection state changes
    peerConnection.oniceconnectionstatechange = () => {
      console.log(`🧊 ICE connection state for ${participantId}:`, peerConnection.iceConnectionState);
    };

    // Add local stream to peer connection
    if (this.localStream) {
      this.localStream.getTracks().forEach(track => {
        if (this.localStream) {
          console.log(`➕ Adding ${track.kind} track to peer connection for ${participantId}`);
          peerConnection.addTrack(track, this.localStream);
        }
      });
    }

    this.peerConnections.set(participantId, peerConnection);
    return peerConnection;
  }

  // Handle incoming offer
  private async handleOffer(data: any): Promise<void> {
    try {
      const { offer, from } = data;
      console.log(`📥 Received offer from ${from}`);
      
      // Get or create peer connection
      let peerConnection = this.peerConnections.get(from);
      if (!peerConnection) {
        console.log(`🆕 Creating new peer connection for ${from}`);
        peerConnection = this.createPeerConnection(from);
      }
      
      await peerConnection.setRemoteDescription(new RTCSessionDescription(offer));
      const answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);
      
      console.log(`📤 Sending answer to ${from}`);
      socketService.sendAnswer(answer, from);
    } catch (error) {
      console.error('❌ Error handling offer:', error);
    }
  }

  // Handle incoming answer
  private async handleAnswer(data: any): Promise<void> {
    try {
      const { answer, from } = data;
      console.log(`📥 Received answer from ${from}`);
      const peerConnection = this.peerConnections.get(from);
      
      if (peerConnection) {
        await peerConnection.setRemoteDescription(new RTCSessionDescription(answer));
        console.log(`✅ Set remote description for ${from}`);
      } else {
        console.warn(`⚠️ No peer connection found for ${from}`);
      }
    } catch (error) {
      console.error('❌ Error handling answer:', error);
    }
  }

  // Handle incoming ICE candidate
  private async handleIceCandidate(data: any): Promise<void> {
    try {
      const { candidate, from } = data;
      const peerConnection = this.peerConnections.get(from);
      
      if (peerConnection) {
        await peerConnection.addIceCandidate(new RTCIceCandidate(candidate));
        console.log(`🧊 Added ICE candidate from ${from}`);
      } else {
        console.warn(`⚠️ No peer connection found for ICE candidate from ${from}`);
      }
    } catch (error) {
      console.error('❌ Error handling ICE candidate:', error);
    }
  }

  // Create offer for a new participant
  async createOffer(participantId: string): Promise<void> {
    try {
      // Don't create offer if we already have a peer connection for this participant
      if (this.peerConnections.has(participantId)) {
        console.log(`⚠️ Peer connection already exists for ${participantId}`);
        return;
      }

      // Ensure we have local stream before creating offer
      if (!this.localStream) {
        console.warn('⚠️ Local stream not ready, waiting...');
        await new Promise(resolve => setTimeout(resolve, 1000));
        if (!this.localStream) {
          console.error('❌ Cannot create offer without local stream');
          return;
        }
      }

      console.log(`📡 Creating offer for ${participantId}`);
      const peerConnection = this.createPeerConnection(participantId);
      const offer = await peerConnection.createOffer({
        offerToReceiveAudio: true,
        offerToReceiveVideo: true
      });
      await peerConnection.setLocalDescription(offer);
      
      console.log(`📤 Sending offer to ${participantId}`);
      socketService.sendOffer(offer, participantId);
    } catch (error) {
      console.error('❌ Error creating offer:', error);
    }
  }

  // Toggle audio
  toggleAudio(): boolean {
    if (this.localStream) {
      const audioTracks = this.localStream.getAudioTracks();
      audioTracks.forEach(track => {
        track.enabled = !track.enabled;
      });
      this.isAudioEnabled = !this.isAudioEnabled;
      socketService.toggleAudio(this.isAudioEnabled);
      return this.isAudioEnabled;
    }
    return false;
  }

  // Toggle video
  toggleVideo(): boolean {
    if (this.localStream) {
      const videoTracks = this.localStream.getVideoTracks();
      videoTracks.forEach(track => {
        track.enabled = !track.enabled;
      });
      this.isVideoEnabled = !this.isVideoEnabled;
      socketService.toggleVideo(this.isVideoEnabled);
      return this.isVideoEnabled;
    }
    return false;
  }

  // Start screen sharing
  async startScreenShare(): Promise<MediaStream | null> {
    try {
      this.screenStream = await navigator.mediaDevices.getDisplayMedia({
        video: true,
        audio: true
      } as any);

      console.log('🖥️ Screen share started');
      console.log('📹 Screen video tracks:', this.screenStream.getVideoTracks().length);
      console.log('🎤 Screen audio tracks:', this.screenStream.getAudioTracks().length);

      this.isScreenSharing = true;
      socketService.startScreenShare();

      // Replace video track in all peer connections
      const videoTrack = this.screenStream.getVideoTracks()[0];
      this.peerConnections.forEach(async (peerConnection, participantId) => {
        const sender = peerConnection.getSenders().find((s: RTCRtpSender) => 
          s.track && s.track.kind === 'video'
        );
        if (sender && videoTrack) {
          console.log(`🔄 Replacing video track for ${participantId} with screen share`);
          await sender.replaceTrack(videoTrack);
        }
      });

      // If screen has audio, replace audio track as well
      const audioTrack = this.screenStream.getAudioTracks()[0];
      if (audioTrack) {
        this.peerConnections.forEach(async (peerConnection, participantId) => {
          const sender = peerConnection.getSenders().find((s: RTCRtpSender) => 
            s.track && s.track.kind === 'audio'
          );
          if (sender) {
            console.log(`🔄 Replacing audio track for ${participantId} with screen audio`);
            await sender.replaceTrack(audioTrack);
          }
        });
      }

      // Listen for screen share end
      videoTrack.onended = () => {
        this.stopScreenShare();
      };

      return this.screenStream;
    } catch (error) {
      console.error('❌ Failed to start screen sharing:', error);
      throw error;
    }
  }

  // Stop screen sharing
  async stopScreenShare(): Promise<void> {
    if (this.screenStream) {
      console.log('🛑 Stopping screen share');
      this.screenStream.getTracks().forEach(track => track.stop());
      this.screenStream = null;
      this.isScreenSharing = false;
      socketService.stopScreenShare();

      // Replace back to camera and microphone
      if (this.localStream) {
        const videoTrack = this.localStream.getVideoTracks()[0];
        const audioTrack = this.localStream.getAudioTracks()[0];
        
        this.peerConnections.forEach(async (peerConnection, participantId) => {
          // Replace video track
          const videoSender = peerConnection.getSenders().find((s: RTCRtpSender) => 
            s.track && s.track.kind === 'video'
          );
          if (videoSender && videoTrack) {
            console.log(`🔄 Restoring camera for ${participantId}`);
            await videoSender.replaceTrack(videoTrack);
          }

          // Replace audio track back to microphone
          const audioSender = peerConnection.getSenders().find((s: RTCRtpSender) => 
            s.track && s.track.kind === 'audio'
          );
          if (audioSender && audioTrack) {
            console.log(`🔄 Restoring microphone for ${participantId}`);
            await audioSender.replaceTrack(audioTrack);
          }
        });
      }
    }
  }

  // Screen sharing signaling handlers
  private async handleScreenShareOffer(data: any): Promise<void> {
    // Handle screen share offers from other participants
    console.log('📺 Received screen share offer:', data);
  }

  private async handleScreenShareAnswer(data: any): Promise<void> {
    // Handle screen share answers
    console.log('📺 Received screen share answer:', data);
  }

  private async handleScreenShareIceCandidate(data: any): Promise<void> {
    // Handle screen share ICE candidates
    console.log('📺 Received screen share ICE candidate:', data);
  }

  // Get local stream
  getLocalStream(): MediaStream | null {
    return this.localStream;
  }

  // Get remote streams
  getRemoteStreams(): Map<string, MediaStream> {
    return this.remoteStreams;
  }

  // Set callback for remote streams
  onRemoteStream(callback: (stream: MediaStream, participantId: string) => void): void {
    this.mediaStreamCallbacks.set('remoteStream', callback);
  }

  // Get media states
  getMediaStates(): { audio: boolean; video: boolean; screenSharing: boolean } {
    return {
      audio: this.isAudioEnabled,
      video: this.isVideoEnabled,
      screenSharing: this.isScreenSharing
    };
  }

  // Clean up resources
  cleanup(): void {
    // Stop local stream
    if (this.localStream) {
      this.localStream.getTracks().forEach(track => track.stop());
    }

    // Stop screen stream
    if (this.screenStream) {
      this.screenStream.getTracks().forEach(track => track.stop());
    }

    // Close all peer connections
    this.peerConnections.forEach((peerConnection, participantId) => {
      peerConnection.close();
    });

    // Clear maps
    this.peerConnections.clear();
    this.remoteStreams.clear();
    this.mediaStreamCallbacks.clear();
  }

  // Remove participant
  removeParticipant(participantId: string): void {
    const peerConnection = this.peerConnections.get(participantId);
    if (peerConnection) {
      peerConnection.close();
      this.peerConnections.delete(participantId);
    }
    this.remoteStreams.delete(participantId);
  }
}

// Export singleton instance
export const webrtcService = new WebRTCService();
export default webrtcService;