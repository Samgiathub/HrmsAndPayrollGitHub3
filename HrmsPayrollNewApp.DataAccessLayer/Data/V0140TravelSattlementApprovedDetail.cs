using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140TravelSattlementApprovedDetail
{
    public decimal TranId { get; set; }

    public decimal TravelSetApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal ManagerEmpId { get; set; }

    public decimal PendingAmount { get; set; }

    public string? ManagerComment { get; set; }

    public byte? IsApr { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public decimal AdvanceAmount { get; set; }

    public decimal ExpanceIncured { get; set; }

    public decimal ApprovedExpance { get; set; }

    public decimal AmountDiffernce { get; set; }

    public decimal AdjustAmount { get; set; }

    public string? PaymentType { get; set; }

    public decimal? ChequeNo { get; set; }

    public byte TravelAmtInSalary { get; set; }

    public DateTime? EffectSalaryDate { get; set; }

    public string PaymentMode { get; set; } = null!;

    public string ChqueNo { get; set; } = null!;

    public decimal Expence { get; set; }

    public decimal Credit { get; set; }

    public string? Comment { get; set; }

    public string? EmpName { get; set; }

    public string? BranchName { get; set; }

    public string Document { get; set; } = null!;

    public byte EffectSalary { get; set; }

    public string? SalEffectDate { get; set; }

    public string? GstNo { get; set; }
}
