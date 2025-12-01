@isTest
public class NumberToWordsTest {

    @isTest
    static void testRupeesOnly() {
        Decimal amount = 1234;
        String expected = 'One Thousand Two Hundred Thirty-Four Rupees only';
        String actual = NumberToWords.getNumberInWords(amount);
        System.assertEquals(expected, actual);
    }

    @isTest
    static void testRupeesWithPaise() {
        Decimal amount = 1234.56;
        String expected = 'One Thousand Two Hundred Thirty-Four Rupees and Fifty-Six Paise only';
        String actual = NumberToWords.getNumberInWords(amount);
        System.assertEquals(expected, actual);
    }

    @isTest
    static void testOneRupeeOnly() {
        Decimal amount = 1;
        String expected = 'One Rupee only';
        String actual = NumberToWords.getNumberInWords(amount);
        System.assertEquals(expected, actual);
    }

    @isTest
    static void testDollarsOnly() {
        Decimal amount = 1000000;
        String expected = 'One Million Dollars only';
        String actual = NumberToWords.getAmountInDollars(amount);
        System.assertEquals(expected, actual);
    }

    @isTest
    static void testDollarsWithCents() {
        Decimal amount = 10.25;
        String expected = 'Ten Dollars and Twenty-Five Cents only';
        String actual = NumberToWords.getAmountInDollars(amount);
        System.assertEquals(expected, actual);
    }

    @isTest
    static void testOneDollarOneCent() {
        Decimal amount = 1.01;
        String expected = 'One Dollar and One Cent only';
        String actual = NumberToWords.getAmountInDollars(amount);
        System.assertEquals(expected, actual);
    }

    @isTest
    static void testPoundsOnly() {
        Decimal amount = 2500;
        String expected = 'Two Thousand Five Hundred Pounds only';
        String actual = NumberToWords.getAmountInPounds(amount);
        System.assertEquals(expected, actual);
    }

    @isTest
    static void testPoundsWithPence() {
        Decimal amount = 2500.75;
        String expected = 'Two Thousand Five Hundred Pounds and Seventy-Five Pence only';
        String actual = NumberToWords.getAmountInPounds(amount);
        System.assertEquals(expected, actual);
    }

    @isTest
    static void testZeroAmount() {
        Decimal amount = 0;
        String expected = 'Zero Rupees only';
        String actual = NumberToWords.getNumberInWords(amount);
        System.assertEquals(expected, actual);
    }
}