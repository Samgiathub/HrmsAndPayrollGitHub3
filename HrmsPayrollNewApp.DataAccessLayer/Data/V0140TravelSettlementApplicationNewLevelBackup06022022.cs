using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140TravelSettlementApplicationNewLevelBackup06022022
{
    public decimal TravelSetApplicationId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdvanceAmount { get; set; }

    public decimal? Expence { get; set; }

    public decimal? Credit { get; set; }

    public decimal Debit { get; set; }

    public decimal? PendingAmount { get; set; }

    public string? Comment { get; set; }

    public string? Document { get; set; }

    public DateTime ForDate { get; set; }

    public byte VisitedFlag { get; set; }

    public string StatusOld { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? BranchName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal TranId { get; set; }

    public string? Status { get; set; }

    public decimal? RptLevel { get; set; }

    public string StatusName { get; set; } = null!;

    public string StatusNew { get; set; } = null!;

    public string EmpFirstName { get; set; } = null!;

    public string? Supervisor { get; set; }

    public decimal? EmpSuperior { get; set; }

    public decimal BranchId { get; set; }

    public string? DesigName { get; set; }

    public decimal? TravelApplicationId { get; set; }

    public byte EffectSalary { get; set; }

    public string? TravelAppCode { get; set; }

    public string? SalEffectDate { get; set; }

    public decimal ApprovedExpence { get; set; }

    public byte DirectEntry { get; set; }

    public string? GstNo { get; set; }

    public decimal? TravelTypeId { get; set; }
}
