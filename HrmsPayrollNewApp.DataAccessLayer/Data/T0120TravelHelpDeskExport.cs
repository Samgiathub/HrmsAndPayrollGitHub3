using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120TravelHelpDeskExport
{
    public string? AlphaEmpCode { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string ApplicationCode { get; set; } = null!;

    public DateTime ApplicationDate { get; set; }

    public string? PlaceOfVisit { get; set; }

    public string? TravelPurpose { get; set; }

    public decimal? InstructEmpId { get; set; }

    public DateTime? ToDate { get; set; }

    public DateTime? FromDate { get; set; }

    public decimal? Period { get; set; }

    public string? Remarks { get; set; }

    public string? Supervisor { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime ApprovalDate { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public string? ApprovalComments { get; set; }

    public decimal TravelApplicationId { get; set; }

    public string ApplicationStatus { get; set; } = null!;

    public string? BranchName { get; set; }

    public decimal BranchId { get; set; }

    public decimal TravelSetApplicationId { get; set; }
}
