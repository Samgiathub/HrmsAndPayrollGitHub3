using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115TravelSettlementLevelApproval
{
    public decimal TranId { get; set; }

    public decimal TravelSetApplicationId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ManagerEmpId { get; set; }

    public decimal PendingAmount { get; set; }

    public string? ManagerComment { get; set; }

    public byte? IsApr { get; set; }

    public DateTime ApprovalDate { get; set; }

    public decimal AdvanceAmount { get; set; }

    public decimal ExpanceIncured { get; set; }

    public decimal ApprovedExpance { get; set; }

    public decimal AmountDiffernce { get; set; }

    public decimal AdjustAmount { get; set; }

    public decimal? ChequeNo { get; set; }

    public string? PaymentType { get; set; }

    public decimal? RptLevel { get; set; }

    public string Status { get; set; } = null!;

    public byte TravelAmtInSalary { get; set; }

    public DateTime? EffectSalaryDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
