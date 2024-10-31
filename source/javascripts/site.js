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

function getVimeoEmbedUrl(videoId) {
  return `https://player.vimeo.com/video/${videoId}?autoplay=1&title=1&byline=0&portrait=0&controls=1&share=1&pip=0&speed=0&quality=0&collections=0&info=0`;
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

  // Show first grid and activate first button by default
  document.querySelector('.video-grid').classList.add('active');
  document.querySelector('.album-button').classList.add('active');

  buttons.forEach(button => {
    button.addEventListener('click', function() {
      // Remove active class from all buttons
      buttons.forEach(btn => btn.classList.remove('active'));

      // Add active class to clicked button
      this.classList.add('active');

      const albumId = this.dataset.albumId;
      document.querySelectorAll('.video-grid').forEach(grid => {
        grid.classList.toggle('active', grid.dataset.albumId === albumId);
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
        // Log the HLS URL
        const hlsSource = videoElement.querySelector('source[type="application/x-mpegURL"]');
        console.log('HLS URL:', hlsSource.src);

        player = videojs(videoElement, {
          fluid: true,
          controls: true,
          autoplay: true,
          preload: 'auto',
          html5: {
            hls: {
              enableLowInitialPlaylist: true,
              smoothQualityChange: true,
              overrideNative: true,
              debug: true  // Enable HLS debugging
            }
          }
        });

        // Add error handling
        player.on('error', function() {
          console.error('Video Error:', player.error());
        });

        // Log when source is loaded
        player.on('loadedmetadata', function() {
          console.log('Video metadata loaded');
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
