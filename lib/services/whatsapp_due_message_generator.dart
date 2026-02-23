import 'package:intl/intl.dart';
import 'package:smartbecho/models/customer%20dues%20management/customer_due_detail_model.dart';

class WhatsAppDueMessageService {
  
  // Generate personalized due message
  static String generateDueMessage({
    required CustomerDueDetailsModel customerDue,
    required String businessName,
    String? customMessage,
  }) {
    final customer = customerDue.customer;
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    
    String message = '''
🔔 *Pending Due Alert*

Dear ${customer.name ?? 'Customer'},

You have the following outstanding dues with *$businessName*:

📊 *Payment Summary:*
• Total Due: ₹${customerDue.totalDue.toStringAsFixed(2)}
• Total Paid: ₹${customerDue.totalPaid.toStringAsFixed(2)}
• Remaining Due: ₹${customerDue.remainingDue.toStringAsFixed(2)}
• Due Date: ${dateFormat.format(customerDue.paymentRetriableDateTime)}

${_getPaymentStatusEmoji(customerDue)} *Payment Status:* ${_getPaymentStatus(customerDue)}

${customMessage ?? 'Please make the payment at the earliest to avoid disruption of service.'}

Regards,
$businessName
''';

    return message.trim();
  }

  // Generate detailed due message with partial payments
  static String generateDetailedDueMessage({
    required CustomerDueDetailsModel customerDue,
    required String businessName,
    String? customMessage,
  }) {
    final customer = customerDue.customer;
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    
    String message = '''
🔔 *Pending Due Alert*

Dear ${customer.name ?? 'Customer'},

You have the following outstanding dues with *$businessName*:

📊 *Payment Summary:*
• Total Due: ₹${customerDue.totalDue.toStringAsFixed(2)}
• Total Paid: ₹${customerDue.totalPaid.toStringAsFixed(2)}
• Remaining Due: ₹${customerDue.remainingDue.toStringAsFixed(2)}
• Due Date: ${dateFormat.format(customerDue.paymentRetriableDateTime)}
• Payment Progress: ${customerDue.paymentProgress.toStringAsFixed(1)}%

${_getPaymentStatusEmoji(customerDue)} *Payment Status:* ${_getPaymentStatus(customerDue)}
''';

    // Add partial payments history if available
    if (customerDue.partialPayments.isNotEmpty) {
      message += '\n💰 *Payment History:*\n';
      for (var payment in customerDue.partialPayments) {
        message += '• ${dateFormat.format(payment.paidDateTime)}: ₹${payment.paidAmount.toStringAsFixed(2)}\n';
      }
    }

    message += '\n${customMessage ?? 'Please make the payment at the earliest to avoid disruption of service.'}\n\n';
    message += 'Regards,\n$businessName';

    return message.trim();
  }

  // Generate reminder message for overdue payments
  static String generateOverdueReminderMessage({
    required CustomerDueDetailsModel customerDue,
    required String businessName,
    int? daysPastDue,
    String? customMessage,
  }) {
    final customer = customerDue.customer;
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    
    String overdueText = '';
    if (daysPastDue != null && daysPastDue > 0) {
      overdueText = ' (${daysPastDue} days overdue)';
    }

    String message = '''
⚠️ *URGENT: Payment Overdue Alert*

Dear ${customer.name ?? 'Customer'},

This is a reminder that your payment is overdue$overdueText.

🚨 *Outstanding Amount:*
• Total Due: ₹${customerDue.totalDue.toStringAsFixed(2)}
• Amount Paid: ₹${customerDue.totalPaid.toStringAsFixed(2)}
• *Remaining Due: ₹${customerDue.remainingDue.toStringAsFixed(2)}*
• Original Due Date: ${dateFormat.format(customerDue.paymentRetriableDateTime)}

${customMessage ?? 'Please settle this payment immediately to avoid service interruption and additional charges.'}

For any queries, please contact us immediately.

Regards,
$businessName
''';

    return message.trim();
  }

  // Generate thank you message for full payment
  static String generatePaymentReceivedMessage({
    required CustomerDueDetailsModel customerDue,
    required String businessName,
    required double paidAmount,
  }) {
    final customer = customerDue.customer;
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    
    String message = '''
✅ *Payment Received - Thank You!*

Dear ${customer.name ?? 'Customer'},

We have successfully received your payment of ₹${paidAmount.toStringAsFixed(2)}.

📋 *Payment Details:*
• Amount Received: ₹${paidAmount.toStringAsFixed(2)}
• Date: ${dateFormat.format(DateTime.now())}
• Remaining Balance: ₹${customerDue.remainingDue.toStringAsFixed(2)}

${customerDue.isFullyPaid ? '🎉 Your account is now fully settled. Thank you for your prompt payment!' : '📌 Please note: You still have a remaining balance of ₹${customerDue.remainingDue.toStringAsFixed(2)}.'}

Thank you for your business!

Regards,
$businessName
''';

    return message.trim();
  }

  // Generate message for multiple dues (like the reference image)
  static String generateMultipleDuesMessage({
    required List<CustomerDueDetailsModel> customerDues,
    required String businessName,
    required String customerName,
    String? customMessage,
  }) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    
    String message = '''
🔔 *Pending Due Alert*

Dear $customerName,

You have the following outstanding dues with *$businessName*:

''';

    // Add table header
    message += '''
┌─────────────┬─────────────┬─────────────┬─────────────┐
│ Total Due   │ Total Paid  │ Remaining   │ Due Date    │
├─────────────┼─────────────┼─────────────┼─────────────┤
''';

    // Add each due row
    for (var due in customerDues) {
      message += '''│ ${due.totalDue.toStringAsFixed(2).padLeft(11)} │ ${due.totalPaid.toStringAsFixed(2).padLeft(11)} │ ${due.remainingDue.toStringAsFixed(2).padLeft(11)} │ ${dateFormat.format(due.paymentRetriableDateTime).padLeft(11)} │
''';
    }

    message += '''└─────────────┴─────────────┴─────────────┴─────────────┘

''';

    // Calculate totals
    double totalDueAmount = customerDues.fold(0, (sum, due) => sum + due.totalDue);
    double totalPaidAmount = customerDues.fold(0, (sum, due) => sum + due.totalPaid);
    double totalRemainingAmount = customerDues.fold(0, (sum, due) => sum + due.remainingDue);

    message += '''
📊 *Summary:*
• Total Outstanding: ₹${totalDueAmount.toStringAsFixed(2)}
• Total Paid: ₹${totalPaidAmount.toStringAsFixed(2)}
• Total Remaining: ₹${totalRemainingAmount.toStringAsFixed(2)}

${customMessage ?? 'Please make the payment at the earliest to avoid disruption of service.'}

Regards,
$businessName
''';

    return message.trim();
  }

  // Helper method to get payment status
  static String _getPaymentStatus(CustomerDueDetailsModel customerDue) {
    if (customerDue.isFullyPaid) {
      return 'Paid';
    } else if (customerDue.totalPaid > 0) {
      return 'Partially Paid';
    } else {
      return 'Pending';
    }
  }

  // Helper method to get payment status emoji
  static String _getPaymentStatusEmoji(CustomerDueDetailsModel customerDue) {
    if (customerDue.isFullyPaid) {
      return '✅';
    } else if (customerDue.totalPaid > 0) {
      return '🟡';
    } else {
      return '🔴';
    }
  }

  // Check if payment is overdue
  static bool isOverdue(CustomerDueDetailsModel customerDue) {
    return DateTime.now().isAfter(customerDue.paymentRetriableDateTime) && 
           !customerDue.isFullyPaid;
  }

  // Calculate days past due
  static int daysPastDue(CustomerDueDetailsModel customerDue) {
    if (!isOverdue(customerDue)) return 0;
    return DateTime.now().difference(customerDue.paymentRetriableDateTime).inDays;
  }
}