public class NumberToWords {

    private static final String[] units = new String[] {
        '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
        'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
        'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    };

    private static final String[] tens = new String[] {
        '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    };

    
    public static String getNumberInWords(Decimal grandTotal) {
        Long rupees = (Long)grandTotal;
        Integer paise = (Integer)((grandTotal - rupees) * 100);
        
        String result = convertToIndianWords(rupees) + ' Rupee'+ (rupees != 1 ? 's' : '');
        
        if (paise > 0) {
            result += ' and ' + convertToIndianWords(paise) + ' Paise'; 
        }

        return result.trim() + ' only';
    }

    
    public static String getAmountInDollars(Decimal amount) {
        Long dollars = (Long)amount;
        Integer cents = (Integer)((amount - dollars) * 100);

        String result = convertToWords(dollars) + ' Dollar' + (dollars != 1 ? 's' : '');

        if (cents > 0) {
            result += ' and ' + convertToWords(cents) + ' Cent' + (cents != 1 ? 's' : '');
        }

        return result.trim() + ' only';
    }

   
    public static String getAmountInPounds(Decimal amount) {
        Long pounds = (Long)amount;
        Integer pence = (Integer)((amount - pounds) * 100);

        String result = convertToWords(pounds) + ' Pound' + (pounds != 1 ? 's' : '');

        if (pence > 0) {
            result += ' and ' + convertToWords(pence) + ' Pence';
        }

        return result.trim() + ' only';
    }

   
    private static String convertToIndianWords(Long num) {
        if (num == 0) return 'Zero';

        String words = '';

        if ((num / 10000000) > 0) {
            words += convertToIndianWords(num / 10000000) + ' Crore ';
            num = Math.mod(num, 10000000);
        }

        if ((num / 100000) > 0) {
            words += convertToIndianWords(num / 100000) + ' Lakh ';
            num = Math.mod(num, 100000);
        }

        if ((num / 1000) > 0) {
            words += convertToIndianWords(num / 1000) + ' Thousand ';
            num = Math.mod(num, 1000);
        }

        if ((num / 100) > 0) {
            words += convertToIndianWords(num / 100) + ' Hundred ';
            num = Math.mod(num, 100);
        }

        if (num > 0) {
            if (!String.isEmpty(words)) {
                words += '';
            }

            if (num < 20) {
                words += units[(Integer)num];
            } else {
                words += tens[(Integer)(num / 10)];
                if (Math.mod(num, 10) > 0) {
                    words += '-' + units[(Integer)Math.mod(num, 10)];
                }
            }
        }

        return words.trim();
    }

    
    private static String convertToWords(Long num) {
        if (num == 0) return 'Zero';

        String words = '';

        if ((num / 1000000000) > 0) {
            words += convertToWords(num / 1000000000) + ' Billion ';
            num = Math.mod(num, 1000000000);
        }

        if ((num / 1000000) > 0) {
            words += convertToWords(num / 1000000) + ' Million ';
            num = Math.mod(num, 1000000);
        }

        if ((num / 1000) > 0) {
            words += convertToWords(num / 1000) + ' Thousand ';
            num = Math.mod(num, 1000);
        }

        if ((num / 100) > 0) {
            words += convertToWords(num / 100) + ' Hundred ';
            num = Math.mod(num, 100);
        }

        if (num > 0) {
            if (!String.isEmpty(words)) {
                words += '';
            }

            if (num < 20) {
                words += units[(Integer)num];
            } else {
                words += tens[(Integer)(num / 10)];
                if (Math.mod(num, 10) > 0) {
                    words += '-' + units[(Integer)Math.mod(num, 10)];
                }
            }
        }

        return words.trim();
    }
}