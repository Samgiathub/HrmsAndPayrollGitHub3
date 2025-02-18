using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0115TravelApplicationDetailLevelBackupYogesh22112022
{
    public decimal TravelApplicationId { get; set; }

    public DateTime ApplicationDate { get; set; }

    public string ApplicationCode { get; set; } = null!;

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal SEmpId { get; set; }

    public string? Supervisor { get; set; }

    public decimal TravelAppDetailId { get; set; }

    public string PlaceOfVisit { get; set; } = null!;

    public string TravelPurpose { get; set; } = null!;

    public decimal? InstructEmpId { get; set; }

    public string? InstructEmpName { get; set; }

    public decimal TravelModeId { get; set; }

    public string? TravelModeName { get; set; }

    public DateTime FromDate { get; set; }

    public decimal Period { get; set; }

    public DateTime ToDate { get; set; }

    public string? Remarks { get; set; }

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public decimal DesigId { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal LeaveId { get; set; }

    public string LeaveName { get; set; } = null!;

    public decimal CmpId { get; set; }

    public byte ChkAdv { get; set; }

    public byte ChkAgenda { get; set; }

    public string? TourAgenda { get; set; }

    public string? ImpBusinessAppoint { get; set; }

    public string? KraTour { get; set; }

    public string? AttachedDocFile { get; set; }

    public int StateId { get; set; }

    public int CityId { get; set; }

    public string? State { get; set; }

    public string? City { get; set; }

    public decimal LocId { get; set; }

    public string LocName { get; set; } = null!;

    public int ChkInternational { get; set; }

    public decimal ProjectId { get; set; }

    public string ProjectName { get; set; } = null!;

    public string SiteId { get; set; } = null!;

    public DateTime? HalfLeaveDate { get; set; }

    public string? LeaveType { get; set; }

    public decimal NightDay { get; set; }

    public string? GstNo { get; set; }

    public string? WorkTelNo { get; set; }

    public string? MobileNo { get; set; }

    public string? WorkEmail { get; set; }

    public decimal? TravelTypeId { get; set; }

    public string? TravelTypeName { get; set; }
}
