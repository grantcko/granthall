function scrollTrigger(selector) {
  let els = document.querySelectorAll(selector);
  els = Array.from(els);

  let observer = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('active');
        observer.unobserve(entry.target);
      }
    });
  }, {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
  });

  els.forEach(el => {
    observer.observe(el);
  });
}

// Example usage
document.addEventListener('DOMContentLoaded', function() {
  scrollTrigger('.scroll-reveal');
});

// Video Modal Handler
document.addEventListener('DOMContentLoaded', function() {
  const videoModal = document.getElementById('videoModal');
  if (!videoModal) return;

  // Check for video ID in URL hash on page load
  const videoId = window.location.hash.slice(1);
  if (videoId) openVideoModal(videoId);

  // Handle modal opening
  videoModal.addEventListener('show.bs.modal', event => {
    const button = event.relatedTarget;
    const videoId = button.dataset.videoId;
    const videoTitle = button.dataset.videoTitle;

    updateModalContent(videoModal, videoId, videoTitle);
    window.history.pushState({}, '', `#${videoId}`);
  });

  // Handle modal closing
  videoModal.addEventListener('hidden.bs.modal', () => {
    window.history.pushState({}, '', window.location.pathname);
    videoModal.querySelector('iframe').src = '';
  });
});

function updateModalContent(modal, videoId, videoTitle) {
  modal.querySelector('.modal-title').textContent = videoTitle;
  modal.querySelector('iframe').src = getVimeoEmbedUrl(videoId);
}

function openVideoModal(videoId) {
  const button = document.querySelector(`[data-video-id="${videoId}"]`);
  if (!button) return;

  const modal = new bootstrap.Modal(videoModal);
  updateModalContent(videoModal, videoId, button.dataset.videoTitle);
  modal.show();
}

document.addEventListener('DOMContentLoaded', function() {
  // Initialize Justified Gallery
  $("#gallery").justifiedGallery({
    rowHeight: 300,
    margins: 5,
    lastRow: 'justify',
    border: 0,
    captions: false,
    waitThumbnailsLoad: true
  }).on('jg.complete', function() {
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

document.addEventListener('DOMContentLoaded', function() {
  const buttons = document.querySelectorAll('.album-button');
  const videoItems = document.querySelectorAll('.video-item');

  // Set initial state - only show featured videos
  videoItems.forEach(item => {
    if (!item.classList.contains('featured')) {
      item.classList.remove('active');
    }
  });

  // Rest of the button click handling remains the same
  buttons.forEach(button => {
    button.addEventListener('click', () => {
      if (button.classList.contains('active')) {
        console.log('removing active');
        button.classList.remove('active');
        videoItems.forEach(item => {
          item.classList.add('active');
        });
        return;
      }
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

document.addEventListener('DOMContentLoaded', function() {
  // Initialize video players in modals
  document.querySelectorAll('.modal').forEach(modal => {
    const videoElement = modal.querySelector('video');
    if (!videoElement) return;

    let player = null;

    modal.addEventListener('show.bs.modal', function() {
      if (!player) {
        player = videojs(videoElement, {
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

    modal.addEventListener('hidden.bs.modal', function() {
      if (player) {
        player.pause();
      }
    });
  });

  // Your existing gallery code...
});

document.addEventListener('DOMContentLoaded', function() {
  const video = document.getElementById('main-video');
  if (video) {
    // Function to handle video errors
    const handleVideoError = () => {
      console.log('Video playback failed, falling back to poster image');
      video.controls = false; // Hide controls when showing poster
      video.style.objectFit = 'cover'; // Ensure poster covers the area
    };

    if (Hls.isSupported()) {
      const hls = new Hls({
        debug: true
      });
      hls.loadSource(video.querySelector('source').src);
      hls.attachMedia(video);

      hls.on(Hls.Events.ERROR, function(event, data) {
        console.log('HLS error:', data);
        if (data.fatal) {
          handleVideoError();
        }
      });
    } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
      video.src = video.querySelector('source').src;
      video.addEventListener('error', handleVideoError);
    }

    // Add general error handler
    video.addEventListener('error', handleVideoError);
  }
});

document.addEventListener('DOMContentLoaded', function() {
  const videoModals = document.querySelectorAll('.modal');

  videoModals.forEach(modal => {
    // Create a MutationObserver to watch for style changes
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.attributeName === 'style' && modal.style.display === 'none') {
          const iframe = modal.querySelector('iframe.bunny-video-player');
          if (iframe) {
            const currentSrc = iframe.src;
            iframe.src = '';
            setTimeout(() => {
              iframe.src = currentSrc;
            }, 100);
          }
        }
      });
    });

    // Start observing the modal for style changes
    observer.observe(modal, {
      attributes: true,
      attributeFilter: ['style']
    });

    // Also keep the hidden.bs.modal event listener as a backup
    modal.addEventListener('hidden.bs.modal', function() {
      const iframe = this.querySelector('iframe.bunny-video-player');
      if (iframe) {
        const currentSrc = iframe.src;
        iframe.src = '';
        setTimeout(() => {
          iframe.src = currentSrc;
        }, 100);
      }
    });
  });
});

document.addEventListener('DOMContentLoaded', function() {
  console.log('DOM loaded, setting up video controls');
  let currentPlayer = null;

  // First verify Player.js is loaded
  if (typeof playerjs === 'undefined') {
    console.error('Player.js library not loaded! Please check script inclusion');
    return;
  }

  // Initialize player when modal opens
  const videoModals = document.querySelectorAll('.modal');
  console.log('Found video modals:', videoModals.length);

  videoModals.forEach(modal => {
    modal.addEventListener('shown.bs.modal', function() {
      console.log('Modal shown');
      const iframe = this.querySelector('iframe.bunny-video-player');
      console.log('Found iframe:', iframe);

      if (iframe) {
        console.log('Initializing Player.js');
        currentPlayer = new playerjs.Player(iframe);

        currentPlayer.on('ready', () => {
          console.log('Player ready event fired');
          setupSpacebarControl();
        });
      }
    });

    modal.addEventListener('hidden.bs.modal', function() {
      console.log('Modal hidden, clearing player reference');
      currentPlayer = null;
    });
  });

  function setupSpacebarControl() {
    console.log('Setting up spacebar control');
    document.addEventListener('keydown', function(e) {
      // Only handle spacebar if we have an active player and not in an input field
      if (e.code === 'Space' && currentPlayer && !['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) {
        e.preventDefault();
        console.log('Spacebar pressed, toggling play state');
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

document.addEventListener('DOMContentLoaded', function() {
  const videoModals = document.querySelectorAll('.modal');

  videoModals.forEach(modal => {
    // Handle modal closing
    modal.addEventListener('hidden.bs.modal', function() {
      // Find all video elements in this modal
      const videos = modal.querySelectorAll('video, iframe');

      videos.forEach(video => {
        if (video.tagName === 'VIDEO') {
          // Handle native video elements
          video.pause();
          video.currentTime = 0;
        } else if (video.tagName === 'IFRAME') {
          // Handle iframe videos (Bunny.net, Vimeo, etc.)
          const currentSrc = video.src;
          video.src = ''; // Remove source temporarily
          setTimeout(() => {
            video.src = currentSrc; // Restore source
          }, 100);
        }
      });

      // If using VideoJS, handle those players
      const vjsPlayers = modal.querySelectorAll('.video-js');
      vjsPlayers.forEach(player => {
        if (videojs.getPlayer(player)) {
          videojs.getPlayer(player).pause();
        }
      });
    });
  });
});

document.addEventListener('DOMContentLoaded', function() {
  // Check for video ID in URL hash on page load
  const videoId = window.location.hash.slice(1);
  if (videoId) {
    const targetModal = document.getElementById(`modal-${videoId}`);
    if (targetModal) {
      const modal = new bootstrap.Modal(targetModal);
      modal.show();
    }
  }

  // Handle modal opening
  document.querySelectorAll('.modal').forEach(modal => {
    modal.addEventListener('show.bs.modal', event => {
      const videoId = modal.id.replace('modal-', '');
      window.history.pushState({}, '', `#${videoId}`);
    });

    // Handle modal closing
    modal.addEventListener('hidden.bs.modal', () => {
      window.history.pushState({}, '', window.location.pathname);
    });
  });
});
