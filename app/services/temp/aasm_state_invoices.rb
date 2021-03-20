module Temp
  class AasmStateInvoices
    def run
      Invoice.open.each do |i|
        i.update_column(:aasm_state, "open_v2")
      end

      Invoice.paid.each do |i|
        i.update_column(:aasm_state, "paid_v2")
      end

      Invoice.void.each do |i|
        i.update_column(:aasm_state, "void_v2")
      end
    end
  end
end
