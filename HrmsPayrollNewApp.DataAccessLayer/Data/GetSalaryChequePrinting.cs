using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetSalaryChequePrinting
{
    public string CompanyName { get; set; } = null!;

    public decimal CompanyId { get; set; }

    public decimal BankId { get; set; }

    public decimal DateTop { get; set; }

    public decimal DateLeft { get; set; }

    public decimal NameTop { get; set; }

    public decimal NameLeft { get; set; }

    public decimal AmountTop { get; set; }

    public decimal AmountLeft { get; set; }

    public decimal AmtWordsTop { get; set; }

    public decimal AmtWordsLeft { get; set; }

    public decimal AmtWordsTop2 { get; set; }

    public decimal AmtWordsLeft2 { get; set; }

    public string CmpFlag { get; set; } = null!;

    public string SingFlag { get; set; } = null!;

    public decimal CmpTop { get; set; }

    public decimal CmpLeft { get; set; }

    public decimal SingTop { get; set; }

    public decimal SingLeft { get; set; }

    public string CmpName { get; set; } = null!;

    public string PayeeFlag { get; set; } = null!;

    public decimal PayeeTop { get; set; }

    public decimal PayeeLeft { get; set; }

    public string AcNoFlag { get; set; } = null!;

    public decimal AcNoTop { get; set; }

    public decimal AcNoLeft { get; set; }

    public string OverThanFlag { get; set; } = null!;

    public decimal OverThanTop { get; set; }

    public decimal OverThanLeft { get; set; }

    public string DirectorFlag { get; set; } = null!;

    public decimal DirectorTop { get; set; }

    public decimal DirectorLeft { get; set; }

    public string? DirectorName { get; set; }

    public string BearerFlag { get; set; } = null!;

    public decimal BearerTop { get; set; }

    public decimal BearerLeft { get; set; }

    public string BankName { get; set; } = null!;

    public string IsDefault { get; set; } = null!;

    public decimal? NetAmount { get; set; }

    public DateTime GenerateDate { get; set; }

    public string? PaymentMode { get; set; }

    public string? EmpName { get; set; }

    public int? Month { get; set; }

    public int? Year { get; set; }

    public decimal EmpId { get; set; }

    public string? Code { get; set; }

    public decimal? TotalEarnAmount { get; set; }

    public decimal? TotalDeduAmount { get; set; }

    public string? AmountInWord { get; set; }
}
