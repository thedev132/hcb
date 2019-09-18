$(document).on('turbolinks:load', function() {
	const amountToCheckWords = amount => {
		let [dollarsString = '', centsString = ''] = amount.split('.')

		const dollars = dollarsString ? +dollarsString : 0
		let cents = centsString ? +centsString.slice(0, 2) : 0
		if (centsString.length === 1) {
			cents *= 10
		}
		const words = `${BK.numToWords(dollars)} ${
			cents > 0 ? `and ${cents}/100` : 'and 00/100'
		}`
		return words
	}

	$('*[id^="check_lob_address_attributes_"]').on(
		'change paste keyup input',
		event => {
			let fieldName = event.currentTarget.id.replace(
				'check_lob_address_attributes_',
				''
			)

			if (fieldName == 'name') {
				$('[data-behavior~="check_orderof"]').text(
					$(event.currentTarget).val() || '　'
				)
			}
		}
	)

	$('*[id^="check_"]').on('change paste keyup input', event => {
		const fieldName = event.currentTarget.id.replace('check_', '')

		if (fieldName == 'memo') {
			$('[data-behavior~="check_memo"]').text(
				$(event.currentTarget).val() || '　'
			)
		}

		if (fieldName == 'amount') {
			const amount = $(event.currentTarget).val()
			const words = amountToCheckWords(amount)

			$('[data-behavior~="check_amount"]').text(amount || '　')
			$('[data-behavior~="check_amount_words"]').text(words || '　')
		}
	})

	// make the check have words on the show
	if ($('[data-behavior~="fill_check_words"]').length == 1) {
		const amount = $('[data-behavior~="fill_check_words"]')
			.data()
			.checkAmount.toString()
		const words = amountToCheckWords(amount)

		$('[data-behavior~="fill_check_words"]').text(words)
	}

	$('[data-behavior~="check_memo_field"]').on(
		'change paste keyup input',
		event => {
			let characters = $(event.currentTarget).val().length

			$('[data-behavior~="check_characters_update"').text(
				`This will appear on the physical check. You have ${40 -
					characters} characters remaining.`
			)
		}
	)

	let currentPayeeVal = '%person%'
	let currentAmountVal = '%amount%'

	$('[data-behavior~="send_check_modal_trigger"]').click(function(event) {
		const payee = $('[data-behavior~="check_payee_name_field"]').val()
		const amount = $('[data-behavior~="check_amount_field"]').val()

		$('[data-behavior~="modal_confirm_words"]').html(function() {
			return $('[data-behavior~="modal_confirm_words"]')
				.html()
				.replace(currentAmountVal, '$' + amount)
				.replace(currentPayeeVal, payee)
		})

		currentAmountVal = '$' + amount
		currentPayeeVal = payee
	})

	$('[data-behavior~="submit_check"]').click(event => {
		event.preventDefault()
		$('form').submit()
	})
})
