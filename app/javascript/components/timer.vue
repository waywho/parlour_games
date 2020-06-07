<template>
  <div class="base-timer">
    <svg
      class="base-timer__svg"
      viewBox="0 0 100 100"
      xmlns="http://www.w3.org/2000/svg"
      >
      <g class="base-timer__circle">
        <circle
          class="base-timer__path-elapsed"
          cx="50"
          cy="50"
          r="45"
          />
        <path
          :stroke-dasharray="circleDasharray"
          :class="['base-timer__path-remaining', remainingPathColor]"
          d="M 50, 50
            m -45, 0
            a 45,45 0 1,0 90,0
            a 45,45 0 1,0 -90,0"
          ></path>
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
  data: function () {
    return {
      timePassed: 0,
      timerInterval: null,
      alertThreshold: 5,
      warningThreshold: 15
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
    },
    circleDasharray() {
      return `${(this.timeFraction * 283).toFixed(0)} 283`;
    },
    timeFraction() {
      const rawTimeFraction = this.timeLeft / this.timeLimit;
      return rawTimeFraction - (1 / this.timeLimit) * (1 - rawTimeFraction)
    },
    colorCodes() {
      return {
        info: {
          color: "has-text-dark"
        },
        warning: {
          color: "has-text-warning",
          threshold: this.warningThreshold
        },
        alert: {
          color: "has-text-danger",
          threshold: this.alertThreshold
        }
      }
    },
    remainingPathColor() {
      const { alert, warning, info } = this.colorCodes
      if (this.timeLeft <= alert.threshold) {
        return alert.color;
      } else if (this.timeLeft <= warning.threshold) {
        return warning.color;
      } else {
        return info.color;
      }
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
  width: 90px;
  height: 90px;

  &__circle {
    fill: none;
    stroke: none;
  }

  &__path-elapsed {
    stroke-width: 9px;
    stroke: #fff;
  }

  &__label {
    position: absolute;
    width: 90px;
    height: 90px;
    top: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 30px;
  }

  &__path-remaining {
    stroke-width: 9px;
    stroke-linecap: round;
    transform: rotate(90deg);
    transform-origin: center;
    transition: 1s linear all;
    stroke: currentColor;
  }

  &__svg {
    transform: scaleX(-1);
  }
}
</style>
