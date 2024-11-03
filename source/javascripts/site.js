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

// document.addEventListener('DOMContentLoaded', function() {
//   // Handle video stop on modal close
//   const videoModals = document.querySelectorAll('.modal');
//   videoModals.forEach(modal => {
//     modal.addEventListener('hidden.bs.modal', function () {
//       const iframe = this.querySelector('iframe');
//       if (iframe) {
//         // Completely replace the iframe to force a reset
//         const newIframe = iframe.cloneNode(true);
//         iframe.parentNode.replaceChild(newIframe, iframe);
//       }
//     });
//   });
// });

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
  console.log('DOM Content Loaded - Initializing video modals');

  // Handle video modals
  const videoModals = document.querySelectorAll('.modal');
  console.log(`Found ${videoModals.length} video modals`);

  videoModals.forEach(modal => {
    const iframe = modal.querySelector('iframe.bunny-video-player');
    let player = null;

    // fullscreen on "f" key
    modal.addEventListener('keydown', function(event) {
      if (event.key.toLowerCase() === 'f' && !event.ctrlKey && !event.altKey && !event.metaKey) {
        console.log('Fullscreen requested');
        const iframe = modal.querySelector('iframe.bunny-video-player');
        if (!iframe) {
          console.log('No iframe found');
          return;
        }

        // Try to access iframe content
        try {
          const iframeDocument = iframe.contentDocument || iframe.contentWindow.document;
          const fullscreenButton = iframeDocument.querySelector('button[data-plyr="fullscreen"]');
          console.log('Fullscreen button:', fullscreenButton);
          if (fullscreenButton) {
            fullscreenButton.click();
          }
        } catch (error) {
          console.error('Cannot access iframe content:', error);
        }
      }
    });

    // Handle video stop on modal close
    modal.addEventListener('hidden.bs.modal', function () {
      const modalIframe = this.querySelector('iframe');
      if (modalIframe) {
        // Completely replace the iframe to force a reset
        const newIframe = modalIframe.cloneNode(true);
        modalIframe.parentNode.replaceChild(newIframe, modalIframe);
      }
    });
  });
});
