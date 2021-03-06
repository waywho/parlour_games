export default {
	data () {
		return {			
	      message: {
	        show: false,
	        type: null,
	        content: null
	      }
		}
	},
	methods: {
		requiredFieldsErrors: function(fieldKeyArray) {
			let invalidFields = false
			if(fieldKeyArray != null && fieldKeyArray != undefined) {
				fieldKeyArray.forEach( fieldKey => {
					// console.log(fieldKey)
					// console.log(this.formFields[fieldKey].value)
					if(this.formFields[fieldKey].value == null || this.formFields[fieldKey].value == '') {
						this.formFields[fieldKey].classType = 'is-danger'
						this.formFields[fieldKey].message = "This is a required field"
						invalidFields = true
						// console.log(invalidFields)
					} 
				})
			}
			return invalidFields
		},
		passwordCheck: function() {
			if(this.formFields.password.value.length < 6) {
				this.formFields.password.classType = 'is-danger'
				this.formFields.password.message = 'Password is too short'
				return false
			}
			if(this.formFields.password.value != this.formFields.passwordConfirmation.value) {
				this.formFields.passwordConfirmation.classType = 'is-danger'
				this.formFields.passwordConfirmation.message = 'Password confirmation does not match password'
				return false
			} 
			return true
			
		},
		clearErrors: function() {
			this.message = {
	        show: false,
	        type: null,
	        content: null
	      }
			Object.keys(this.formFields).forEach(key => {
				console.log(key)
				this.formFields[key].classType = null
				this.formFields[key].message = null
			})
		},
		showFieldErrors: function (errorObject) {
			console.log(errorObject.response)
			// console.log(errorObject.response.data.errors[0].details)
			if(errorObject == undefined || errorObject == null) {return }
			// console.log(Object.keys(errorDetails))
			this.showGeneralMessage(errorObject.response.statusText, 'is-danger')
		
			if(errorObject.response.data.errors != null || errorObject.response.data.errors != undefined ) {
				let errorDetails = errorObject.response.data.errors
				Object.keys(errorDetails).forEach(key => {
					// console.log(`${key} ${errorDetails[key].join()}`)
					console.log(key)
					console.log(this.formFields[key])
					this.formFields[key].classType = 'is-danger'
					this.formFields[key].message = `${key.charAt(0).toUpperCase() + key.slice(1)} ${errorDetails[key].join(', ')}`
				})
			}
			
		},
		showGeneralMessage: function (message, type) {
			this.message.show = true
      this.message.type = type
      this.message.content = message
		}
	}

}