using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0220TdsChallan
{
    public decimal ChallanId { get; set; }

    public decimal CmpId { get; set; }

    public decimal Month { get; set; }

    public decimal Year { get; set; }

    public DateTime? PaymentDate { get; set; }

    public decimal? BankId { get; set; }

    public string? BankName { get; set; }

    public string? BankBsrCode { get; set; }

    public string? PaidBy { get; set; }

    public string? ChequeNo { get; set; }

    public string? CinNo { get; set; }

    public DateTime? ChequeDate { get; set; }

    public decimal TaxAmount { get; set; }

    public decimal EdCess { get; set; }

    public decimal InterestAmount { get; set; }

    public decimal PenaltyAmount { get; set; }

    public decimal OtherAmount { get; set; }

    public decimal TotalAmount { get; set; }

    public long ChallanType { get; set; }

    public decimal? AdditionalAmount { get; set; }

    public decimal? TaxAmt { get; set; }
}
