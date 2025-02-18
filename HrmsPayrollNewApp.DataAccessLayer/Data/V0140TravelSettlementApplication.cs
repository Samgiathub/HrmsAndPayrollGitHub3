using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140TravelSettlementApplication
{
    public decimal TravelSetApplicationId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdvanceAmount { get; set; }

    public decimal Expence { get; set; }

    public decimal Credit { get; set; }

    public decimal Debit { get; set; }

    public string? Comment { get; set; }

    public string? Document { get; set; }

    public DateTime ForDate { get; set; }

    public byte VisitedFlag { get; set; }

    public string Status { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal TranId { get; set; }

    public string StatusName { get; set; } = null!;

    public string EmpFirstName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public byte EffectSalary { get; set; }

    public string? TravelAppCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal ApprovedExpance { get; set; }

    public byte DirectEntry { get; set; }

    public string? GstNo { get; set; }

    public int? ProofCount { get; set; }

    public DateTime ApplicationDate { get; set; }
}
