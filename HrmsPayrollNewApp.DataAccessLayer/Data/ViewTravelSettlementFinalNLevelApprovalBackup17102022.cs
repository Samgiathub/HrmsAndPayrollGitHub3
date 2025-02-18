using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewTravelSettlementFinalNLevelApprovalBackup17102022
{
    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? Supervisor { get; set; }

    public decimal TravelSetApplicationId { get; set; }

    public decimal? TravelApplicationId { get; set; }

    public string? BranchName { get; set; }

    public string? DesigName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public DateTime ApplicationDate { get; set; }

    public DateTime ForDate { get; set; }

    public string? Status { get; set; }

    public string ApplicationStatus { get; set; } = null!;

    public decimal AppCode { get; set; }

    public decimal TravelApprovalId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public decimal CmpId { get; set; }

    public decimal SEmpIdA { get; set; }

    public decimal AdvanceAmount { get; set; }

    public decimal SEmpId { get; set; }

    public decimal TranId { get; set; }

    public string? TravelAppCode { get; set; }

    public decimal ApprovedExpense { get; set; }

    public byte VisitedFlag { get; set; }
}
