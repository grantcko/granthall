// Scroll animation function that reveals elements as they come into view
function scrollTrigger(selector) {
  // Get all elements matching the selector and convert to array
  let els = document.querySelectorAll(selector);
  els = Array.from(els);

  // Create an Intersection Observer to watch when elements become visible
  let observer = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      // When element becomes visible
      if (entry.isIntersecting) {
        entry.target.classList.add('active'); // Add 'active' class
        observer.unobserve(entry.target);     // Stop watching this element
      }
    });
  }, {
    root: null,           // Use viewport as root
    rootMargin: '0px',    // No margin
    threshold: 0.1        // Trigger when 10% of element is visible
  });

  // Start observing each element
  els.forEach(el => {
    observer.observe(el);
  });
}

// Initialize scroll animations when page loads
document.addEventListener('DOMContentLoaded', function() {
  scrollTrigger('.scroll-reveal');
});

// Video Modal Handler - Manages video popups
document.addEventListener('DOMContentLoaded', function() {
  const videoModal = document.getElementById('videoModal');
  if (!videoModal) return;

  // Check URL for video ID on page load (for direct links to videos)
  const videoId = window.location.hash.slice(1);
  if (videoId) openVideoModal(videoId);

  // When modal opens
  videoModal.addEventListener('show.bs.modal', event => {
    const button = event.relatedTarget;
    const videoId = button.dataset.videoId;
    const videoTitle = button.dataset.videoTitle;

    // Update modal content and URL
    updateModalContent(videoModal, videoId, videoTitle);
    window.history.pushState({}, '', `#${videoId}`);
  });

  // When modal closes
  videoModal.addEventListener('hidden.bs.modal', () => {
    // Clear URL hash and video source
    window.history.pushState({}, '', window.location.pathname);
    videoModal.querySelector('iframe').src = '';
  });
});

// Helper function to update modal content
function updateModalContent(modal, videoId, videoTitle) {
  modal.querySelector('.modal-title').textContent = videoTitle;
  modal.querySelector('iframe').src = getVimeoEmbedUrl(videoId);
}

// Helper function to open video modal programmatically
function openVideoModal(videoId) {
  const button = document.querySelector(`[data-video-id="${videoId}"]`);
  if (!button) return;

  const modal = new bootstrap.Modal(videoModal);
  updateModalContent(videoModal, videoId, button.dataset.videoTitle);
  modal.show();
}

// Photo Gallery Initialization
document.addEventListener('DOMContentLoaded', function() {
  // Initialize Justified Gallery plugin with configuration
  $("#gallery").justifiedGallery({
    rowHeight: 300,
    margins: 5,
    lastRow: 'justify',
    border: 0,
    captions: false,
    waitThumbnailsLoad: true
  }).on('jg.complete', function() {
    // After gallery loads, initialize PhotoSwipe lightbox
    let lightbox = new PhotoSwipeLightbox({
      gallery: '#gallery',
      children: 'a',
      pswpModule: PhotoSwipe,
      closeOnVerticalDrag: true,
      clickToCloseNonZoomable: false,
      imageClickAction: 'zoom',
      tapAction: 'zoom',
      doubleTapAction: 'zoom',
      bgOpacity: 0.8,
      showHideAnimationType: 'fade'
    });

    lightbox.init();
  });
});

// Album Filter System
document.addEventListener('DOMContentLoaded', function() {
  const buttons = document.querySelectorAll('.album-button');
  const videoItems = document.querySelectorAll('.video-item');

  // Initially show only featured videos
  videoItems.forEach(item => {
    if (!item.classList.contains('featured')) {
      item.classList.remove('active');
    }
  });

  // Handle album filter button clicks
  buttons.forEach(button => {
    button.addEventListener('click', () => {
      // If clicking active button, show all videos
      if (button.classList.contains('active')) {
        console.log('removing active');
        button.classList.remove('active');
        videoItems.forEach(item => {
          item.classList.add('active');
        });
        return;
      }

      // Otherwise, filter videos by album
      const albumId = button.dataset.albumId;
      console.log(albumId);
      buttons.forEach(button => {
        button.classList.remove('active');
      });
      button.classList.add('active');

      videoItems.forEach(item => {
        if (!item.classList.contains(albumId)) {
          item.classList.remove('active');
        }
        if (item.classList.contains(albumId)) {
          item.classList.add('active');
        }
      });
    });
  });
});

// Video.js Player Initialization
document.addEventListener('DOMContentLoaded', function() {
  // Initialize video players in modals
  document.querySelectorAll('.modal').forEach(modal => {
    const videoElement = modal.querySelector('video');
    if (!videoElement) return;

    let player = null;

    // Initialize player when modal opens
    modal.addEventListener('show.bs.modal', function() {
      if (!player) {
        player = videojs(videoElement, {
          // Video.js configuration options
          fluid: true,
          controls: true,
          autoplay: false,
          preload: 'auto',
          playbackRates: [0.5, 1, 1.5, 2],
          html5: {
            hls: {
              enableLowInitialPlaylist: true,
              smoothQualityChange: true,
              overrideNative: true
            },
            nativeVideoTracks: false,
            nativeAudioTracks: false,
            nativeTextTracks: false
          }
        });
      }
    });

    // Pause video when modal closes
    modal.addEventListener('hidden.bs.modal', function() {
      if (player) {
        player.pause();
      }
    });
  });
});

// HLS (HTTP Live Streaming) Video Handler
document.addEventListener('DOMContentLoaded', function() {
  const video = document.getElementById('main-video');
  if (video) {
    // Error handling function
    const handleVideoError = () => {
      console.log('Video playback failed, falling back to poster image');
      video.controls = false;
      video.style.objectFit = 'cover';
    };

    // Initialize HLS if supported
    if (Hls.isSupported()) {
      const hls = new Hls({ debug: true });
      hls.loadSource(video.querySelector('source').src);
      hls.attachMedia(video);

      // Handle HLS errors
      hls.on(Hls.Events.ERROR, function(event, data) {
        console.log('HLS error:', data);
        if (data.fatal) {
          handleVideoError();
        }
      });
    }
    // Fallback for Safari which has native HLS support
    else if (video.canPlayType('application/vnd.apple.mpegurl')) {
      video.src = video.querySelector('source').src;
      video.addEventListener('error', handleVideoError);
    }

    video.addEventListener('error', handleVideoError);
  }
});

// Bunny.net Video Player Reset Handler
document.addEventListener('DOMContentLoaded', function() {
  const videoModals = document.querySelectorAll('.modal');

  videoModals.forEach(modal => {
    modal.addEventListener('hidden.bs.modal', function() {
      const iframe = modal.querySelector('iframe.bunny-video-player');
      if (iframe && iframe.src) {
        iframe.src = iframe.src.replace('autoplay=true', 'autoplay=false');
      }
    });

    modal.addEventListener('show.bs.modal', function() {
      const iframe = modal.querySelector('iframe.bunny-video-player');
      if (iframe && iframe.src) {
        iframe.src = iframe.src.replace('autoplay=false', 'autoplay=true');
      }
    });
  });
});

// Spacebar Video Control Setup
document.addEventListener('DOMContentLoaded', function() {
  console.log('DOM loaded, setting up video controls');
  let currentPlayer = null;

  // Verify Player.js is available
  if (typeof playerjs === 'undefined') {
    console.error('Player.js library not loaded!');
    return;
  }

  // Initialize player controls for each modal
  const videoModals = document.querySelectorAll('.modal');

  videoModals.forEach(modal => {
    // Setup player when modal opens
    modal.addEventListener('shown.bs.modal', function() {
      const iframe = this.querySelector('iframe.bunny-video-player');

      if (iframe) {
        currentPlayer = new playerjs.Player(iframe);
        currentPlayer.on('ready', () => {
          setupSpacebarControl();
        });
      }
    });

    // Clear player reference when modal closes
    modal.addEventListener('hidden.bs.modal', function() {
      currentPlayer = null;
    });
  });

  // Setup spacebar control for play/pause
  function setupSpacebarControl() {
    document.addEventListener('keydown', function(e) {
      if (e.code === 'Space' && currentPlayer && !['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) {
        e.preventDefault();
        currentPlayer.getPaused(function(isPaused) {
          console.log('Current player state - isPaused:', isPaused);
          if (isPaused) {
            console.log('Playing video');
            currentPlayer.play();
          } else {
            console.log('Pausing video');
            currentPlayer.pause();
          }
        });
      }
    });
  }
});

// Video Cleanup on Modal Close
document.addEventListener('DOMContentLoaded', function() {
  const videoModals = document.querySelectorAll('.modal');

  videoModals.forEach(modal => {
    modal.addEventListener('hidden.bs.modal', function() {
      // Reset all video elements in modal
      const videos = modal.querySelectorAll('video, iframe');

      videos.forEach(video => {
        if (video.tagName === 'VIDEO') {
          // Reset native video elements
          video.pause();
          video.currentTime = 0;
        } else if (video.tagName === 'IFRAME' && video.classList.contains('bunny-video-player')) {
          // Only handle Bunny.net video iframes
          const currentSrc = video.src;
          if (currentSrc.includes('mediadelivery.net')) { // Additional check
            video.src = ''; // Remove source temporarily
            setTimeout(() => {
              video.src = currentSrc; // Restore source
            }, 100);
          }
        }
      });

      // Reset Video.js players
      const vjsPlayers = modal.querySelectorAll('.video-js');
      vjsPlayers.forEach(player => {
        if (videojs.getPlayer(player)) {
          videojs.getPlayer(player).pause();
        }
      });
    });
  });
});

// URL Hash Management for Videos
document.addEventListener('DOMContentLoaded', function() {
  // Open video modal if ID is in URL
  const videoId = window.location.hash.slice(1);
  if (videoId) {
    const targetModal = document.getElementById(`modal-${videoId}`);
    if (targetModal) {
      const modal = new bootstrap.Modal(targetModal);
      modal.show();
    }
  }

  // Update URL when modals open/close
  document.querySelectorAll('.modal').forEach(modal => {
    modal.addEventListener('show.bs.modal', event => {
      const videoId = modal.id.replace('modal-', '');
      window.history.pushState({}, '', `#${videoId}`);
    });

    modal.addEventListener('hidden.bs.modal', () => {
      window.history.pushState({}, '', window.location.pathname);
    });
  });
});
