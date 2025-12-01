public class CurrencyFormatter {

    public static String formatAmount(Decimal amount, String opportunityCurrency) {
        if (String.isBlank(opportunityCurrency)) {
            return String.valueOf(amount.setScale(2));
        }

        if (opportunityCurrency.equalsIgnoreCase('INR')) {
            return formatIndianStyle(amount);
        } else {
            return formatWesternStyle(amount);
        }
    }

    private static String formatIndianStyle(Decimal amount) {
        String amountStr = String.valueOf(amount.setScale(2));
        String[] parts = amountStr.split('\\.');
        String intPart = parts[0];
        String decimalPart = parts[1];

        String formatted = '';
        Integer len = intPart.length();

        if (len > 3) {
            String lastThree = intPart.substring(len - 3);
            String rest = intPart.substring(0, len - 3);
            while (rest.length() > 2) {
                formatted = ',' + rest.substring(rest.length() - 2) + formatted;
                rest = rest.substring(0, rest.length() - 2);
            }
            formatted = rest + formatted + ',' + lastThree;
        } else {
            formatted = intPart;
        }

        return formatted + '.' + decimalPart;
    }

    public static String formatWesternStyle(Decimal amount) {
        String[] parts = String.valueOf(amount).split('\\.');
        String intPart = parts[0];
        String decPart = (parts.size() > 1) ? '.' + parts[1] : '';

        String result = '';
        Integer count = 0;

        for (Integer i = intPart.length() - 1; i >= 0; i--) {
            result = intPart.substring(i, i + 1) + result;
            count++;
            if (Math.mod(count,3) == 0 && i != 0) {
                result = ',' + result;
            }
        }
        return result + decPart;
    }
}