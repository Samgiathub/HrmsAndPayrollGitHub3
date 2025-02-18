using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120BondApproval
{
    public decimal BondAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal BondId { get; set; }

    public DateTime BondAprDate { get; set; }

    public string BondAprCode { get; set; } = null!;

    public decimal BondAprAmount { get; set; }

    public decimal BondAprNoOfInstallment { get; set; }

    public decimal BondAprInstallmentAmount { get; set; }

    public decimal BondAprDeductFromSal { get; set; }

    public string? DeductionType { get; set; }

    public DateTime? InstallmentStartDate { get; set; }

    public decimal BondPaidAmount { get; set; }

    public decimal NoOfInstallmentPaid { get; set; }

    public decimal? BondAprPendingAmount { get; set; }

    public string? BondApprovalRemarks { get; set; }

    public string? AttachmentPath { get; set; }

    public string BondReturnMode { get; set; } = null!;

    public int? BondReturnMonth { get; set; }

    public int? BondReturnYear { get; set; }

    public string? BondReturnStatus { get; set; }

    public DateTime? BondReturnDate { get; set; }

    public decimal? PaymentProcessId { get; set; }

    public virtual T0040BondMaster Bond { get; set; } = null!;

    public virtual ICollection<T0130BondInstallmentDetail> T0130BondInstallmentDetails { get; set; } = new List<T0130BondInstallmentDetail>();

    public virtual ICollection<T0210MonthlyBondPayment> T0210MonthlyBondPayments { get; set; } = new List<T0210MonthlyBondPayment>();
}
