using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150TravelSettlementApproval
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
}
