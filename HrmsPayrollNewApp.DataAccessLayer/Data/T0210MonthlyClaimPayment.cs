using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210MonthlyClaimPayment
{
    public decimal ClaimPayId { get; set; }

    public decimal ClaimAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SalTranId { get; set; }

    public string? ClaimPayCode { get; set; }

    public decimal ClaimPayAmount { get; set; }

    public string ClaimPayComments { get; set; } = null!;

    public DateTime ClaimPaymentDate { get; set; }

    public string ClaimPaymentType { get; set; } = null!;

    public string BankName { get; set; } = null!;

    public string ClaimChequeNo { get; set; } = null!;

    public decimal? TempSalTranId { get; set; }

    public string? VoucherNo { get; set; }

    public DateTime? VoucherDate { get; set; }

    public virtual T0120ClaimApproval ClaimApr { get; set; } = null!;
}
