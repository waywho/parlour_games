<template>
  <div class="base-timer">
    <svg 
      width="150"
      height="70"
      class="base-timer__svg"
      viewBox="0 0 150 70"
      xmlns="http://www.w3.org/2000/svg"
      >
      <g class="base-timer__square">
        <rect
          class="base-timer__path-elapsed"
          width="100%"
          height="100%"
          />
        </g>
      </svg>
      <span class="base-timer__label">
        {{formattedTimeLeft}}
      </span>
  </div>
</template>

<script>

export default {
  props: {
    timeLimit: {
      type: Number,
      required: true
    }
  },
  computed: {
    timeLeft () {
      return this.timeLimit - this.timePassed
    },
    formattedTimeLeft() {
      const timeLeft = this.timeLeft
      const minutes = Math.floor(timeLeft / 60)
      let seconds = timeLeft % 60

      if(seconds < 10) {
        seconds = `0${seconds}`
      }

      return `${minutes}:${seconds}`
    }
  },
  data: function () {
    return {
      timePassed: 0,
      timerInterval: null
    }
  },
  watch: {
    timeLeft (newVal) {
      if(newVal === 0) {
        this.onTimesUp();
      }
    }
  },
  methods: {
    startTimer() {
      this.timerInterval = setInterval(() => {
        this.timePassed += 1
      }, 1000)
    },
    stopTimer() {
      clearInterval(this.timerInterval)
    },
    onTimesUp() {
      this.stopTimer();
      this.resetTimer();
      console.log('times up')
      this.$emit('times-up')
    },
    resetTimer() {
      clearInterval(this.timerInterval);
      this.timerInterval = null
      this.timePassed = 0
    }
  },
  created () {

  }
}
</script>

<style scoped lang="scss">
.base-timer {
  position: relative;
  width: 150px;
  height: 70px;

  &__square {
    fill: none;
    stroke: none;
  }

  &__path-elapsed {
    stroke-width: 18px;
    stroke: #363636;
  }

  &__label {
    position: absolute;
    width: 150px;
    height: 70px;
    top: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 40px;
  }
}
</style>
