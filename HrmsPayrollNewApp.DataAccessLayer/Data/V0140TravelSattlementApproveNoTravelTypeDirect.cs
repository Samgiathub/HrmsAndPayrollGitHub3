using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140TravelSattlementApproveNoTravelTypeDirect
{
    public decimal TravelApprovalId { get; set; }

    public DateTime ApprovalDate { get; set; }

    public string? ApprovalComments { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal SEmpId { get; set; }

    public decimal? TravelApplicationId { get; set; }

    public decimal Total { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string SEmpFullName { get; set; } = null!;

    public string EmpFirstName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public decimal TravelSetApplicationId { get; set; }

    public string Status { get; set; } = null!;

    public string? Document { get; set; }

    public string? EmpVisit { get; set; }

    public string? TravelAppCode { get; set; }

    public DateTime? SetApproveDate { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public byte IsForeign { get; set; }

    public decimal DesigId { get; set; }

    public string? Oddates { get; set; }

    public byte VisitedFlag { get; set; }

    public string? GstNo { get; set; }

    public decimal? TravelTypeId { get; set; }

    public string? TravelTypeName { get; set; }
}
