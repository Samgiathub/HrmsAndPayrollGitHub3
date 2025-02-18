using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0130ApprovalDetailNew
{
    public decimal TravelApprovalId { get; set; }

    public DateTime ApprovalDate { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? SEmpId { get; set; }

    public string? Supervisor { get; set; }

    public decimal? TravelApprovalDetailId { get; set; }

    public string? PlaceOfVisit { get; set; }

    public string? TravelPurpose { get; set; }

    public string? AttachedDocFile { get; set; }

    public decimal? ApplicationCode { get; set; }

    public decimal? InstructEmpId { get; set; }

    public decimal? LeaveId { get; set; }

    public string LeaveName { get; set; } = null!;

    public string? InstructEmpName { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TravelModeId { get; set; }

    public string? TravelModeName { get; set; }

    public DateTime? FromDate { get; set; }

    public decimal? Period { get; set; }

    public DateTime? ToDate { get; set; }

    public string? Remarks { get; set; }

    public int? FromStateId { get; set; }

    public string? FromState { get; set; }

    public string? FromCityName { get; set; }

    public decimal? StateId { get; set; }

    public string? State { get; set; }

    public string? CityName { get; set; }

    public string LocName { get; set; } = null!;

    public decimal ChkInternational { get; set; }

    public decimal ProjectId { get; set; }

    public string ProjectName { get; set; } = null!;

    public string SiteId { get; set; } = null!;

    public string? GstNo { get; set; }

    public string? ReasonName { get; set; }
}
