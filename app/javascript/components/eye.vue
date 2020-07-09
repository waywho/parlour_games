<template>
  <div>
  <svg v-if="eyeOpen || sessionLooking" :width="size" :height="size" viewBox="0 0 30 30" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <path d="M0,15.089434 C0,16.3335929 5.13666091,24.1788679 14.9348958,24.1788679 C24.7325019,24.1788679 29.8697917,16.3335929 29.8697917,15.089434 C29.8697917,13.8456167 24.7325019,6 14.9348958,6 C5.13666091,6 0,13.8456167 0,15.089434 Z" id="outline"></path>
        <mask :id="prepend + 'mask' + index">
          <rect width="100%" height="100%" fill="white"></rect>
          <use xlink:href="#outline" :class="[ blink ? 'lid-blink' : '']" fill="black"/>
        </mask>
    </defs>
    <g :id="prepend +'eye' + index" :class="[ blink ? 'eye-squeeze' : '', randomSelectEyeTwich]">
        <path d="M0,15.089434 C0,16.3335929 5.13666091,24.1788679 14.9348958,24.1788679 C24.7325019,24.1788679 29.8697917,16.3335929 29.8697917,15.089434 C29.8697917,13.8456167 24.7325019,6 14.9348958,6 C5.13666091,6 0,13.8456167 0,15.089434 Z M14.9348958,22.081464 C11.2690863,22.081464 8.29688487,18.9510766 8.29688487,15.089434 C8.29688487,11.2277914 11.2690863,8.09740397 14.9348958,8.09740397 C18.6007053,8.09740397 21.5725924,11.2277914 21.5725924,15.089434 C21.5725924,18.9510766 18.6007053,22.081464 14.9348958,22.081464 L14.9348958,22.081464 Z M18.2535869,15.089434 C18.2535869,17.0200844 16.7673289,18.5857907 14.9348958,18.5857907 C13.1018339,18.5857907 11.6162048,17.0200844 11.6162048,15.089434 C11.6162048,13.1587835 13.1018339,11.593419 14.9348958,11.593419 C15.9253152,11.593419 14.3271242,14.3639878 14.9348958,15.089434 C15.451486,15.7055336 18.2535869,14.2027016 18.2535869,15.089434 L18.2535869,15.089434 Z" fill="#020202"></path>
        <use xlink:href="#outline" :mask="'url(#'+ prepend +'mask'+ index +')'" fill="#020202"/>
    </g>
  </svg>
  <svg v-else version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="100px" height="137.218px" viewBox="0 0 137.218 137.218" style="enable-background:new 0 0 137.218 137.218;" xml:space="preserve">
    <g class="eye-twitch">
      <path d="M128.942,77.41l0.87-0.574c1.693-1.171,2.091-3.483,0.919-5.165c-1.182-1.697-3.507-2.08-5.165-0.925
        c-58.011,40.558-100.239,1.996-102.013,0.339c-1.497-1.401-3.856-1.33-5.25,0.158c-1.401,1.494-1.333,3.831,0.149,5.237
        c0.08,0.076,1.401,1.285,3.812,3.074l-7.431,12.255c-1.06,1.748-0.504,4.03,1.245,5.099c0.598,0.36,1.277,0.541,1.934,0.541
        c1.249,0,2.465-0.635,3.172-1.778l7.266-11.973c4.074,2.48,9.298,5.188,15.522,7.476l-3.581,11.972
        c-0.593,1.971,0.516,4.027,2.475,4.613l1.068,0.158c1.583,0,3.063-1.04,3.545-2.649l3.546-11.808
        c5.745,1.571,12.172,2.632,19.108,2.884v11.858c0,2.052,1.657,3.709,3.709,3.709c2.05,0,3.708-1.657,3.708-3.709V96.278
        c6.052-0.332,12.466-1.373,19.163-3.283l4.565,12.038c0.569,1.483,1.979,2.391,3.468,2.391l1.312-0.234
        c1.915-0.728,2.886-2.867,2.158-4.781l-4.445-11.729c6.098-2.265,12.401-5.247,18.911-9.203l6.009,8.021
        c0.732,0.969,1.849,1.489,2.965,1.489c0.778,0,1.555-0.236,2.222-0.745c1.644-1.23,1.976-3.555,0.752-5.192L128.942,77.41z"/>
      
    </g>
  </svg>
  </div>
</template>

<script>
import { bus } from '../packs/application';

export default {
  props:['openEye', 'sessionLooking', 'prepend', 'session', 'index', 'size'],
  data: function () {
    return {
      blink: false
    }
  },
  computed: {
    eyeOpen: function() {
      if(this.sessionLooking || this.openEye) {
        return true
      } else {
        return false
      }
    },
    randomSelectEyeTwich: function() {
      var randClass = Math.floor(Math.random() * 4) + 1
      return `eye-twitch-${randClass}`
    }
  },
  methods: {
    makeBlink: function() {
      this.blink = true
      setTimeout(() => {
        this.blink = false
      }, 1000)
    }
  },
  created () {
    bus.$on('blink', (killer) => {
      if(killer == this.session.id) {
        this.makeBlink()
      }
    })
    
  }
}
</script>

<style scoped lang="scss">
.lid-blink {
  animation: blink 1s;
  animation-iteration-count: 1;
}
.eye-squeeze {
  animation: squeeze 1s;
  animation-iteration-count: 1;
}

.eye-twitch {
  animation: twitch 2s infinite;
}

.eye-twitch-1 {
  animation: twitch 2.1s infinite;
}

.eye-twitch-2 {
  animation: twitch 3s infinite;
}

.eye-twitch-3 {
  animation: twitch 1.6s infinite;
}

.eye-twitch-4 {
  animation: twitch 2.4s infinite;
}

.eye-twitch-5 {
  animation: twitch 3.6s infinite;
}

@keyframes fastblink {
  10% {
  transform: none;
    animation-timing-function: ease-in;
  }
  13% {
    transform: translateY(15px) scaleY(0);
  }
  90% {
    animation-timing-function: ease-out;
  }
}

@keyframes blink {
  10% {
  transform: none;
    animation-timing-function: ease-in;
  }
  13% {
    transform: translateY(15px) scaleY(0);
  }
  90% {
    animation-timing-function: ease-out;
  }
}
@keyframes squeeze {
  10% {
    transform: none;
    animation-timing-function: ease-in;
  }
  13% {
    transform: translateY(3px) scaleY(0.8);
  }
  90% {
    animation-timing-function: ease-out;
  }
}

@keyframes twitch {
  90% {
    transform: none;
    animation-timing-function: ease-in;
  }
  93% {
    transform: translateY(2px) scaleY(0.9);
  }
  100% {
    animation-timing-function: ease-out;
  }
}
</style>
