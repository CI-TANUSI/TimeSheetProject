@isTest
private class CurrencyFormatterTest {

    @isTest
    static void testFormatAmountINR() {
        Decimal amount = 1234567.89;
        String formatted = CurrencyFormatter.formatAmount(amount, 'INR');
        Assert.areequal('12,34,567.89', formatted, 'INR formatting failed');
    }

    @isTest
    static void testFormatAmountUSD() {
        Decimal amount = 1234567.89;
        String formatted = CurrencyFormatter.formatAmount(amount, 'USD');
        Assert.areequal('1,234,567.89', formatted, 'USD formatting failed');
    }

    @isTest
    static void testFormatAmountEmptyCurrency() {
        Decimal amount = 9876.5;
        String formatted = CurrencyFormatter.formatAmount(amount, '');
        Assert.areequal('9876.50', formatted, 'Empty currency formatting failed');
    }

    @isTest
    static void testFormatAmountNullCurrency() {
        Decimal amount = 9876.5;
        String formatted = CurrencyFormatter.formatAmount(amount, null);
        Assert.areequal('9876.50', formatted, 'Null currency formatting failed');
    }

    @isTest
    static void testSmallINRAmount() {
        Decimal amount = 123.4;
        String formatted = CurrencyFormatter.formatAmount(amount, 'INR');
        Assert.areequal('123.40', formatted, 'Small INR amount formatting failed');
    }

    @isTest
    static void testSmallWesternAmount() {
        Decimal amount = 123.4;
        String formatted = CurrencyFormatter.formatAmount(amount, 'EUR');
        Assert.areequal('123.4', formatted, 'Small western amount formatting failed');
    }
}