using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090ChangeRequestFinalNLevelApproval
{
    public decimal RequestId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? RequestTypeId { get; set; }

    public string? ChangeReason { get; set; }

    public DateTime? RequestDate { get; set; }

    public DateTime? ShiftFromDate { get; set; }

    public DateTime? ShiftToDate { get; set; }

    public string? CurrDetails { get; set; }

    public string? NewDetails { get; set; }

    public string? CurrTehsil { get; set; }

    public string? CurrDistrict { get; set; }

    public string? CurrThana { get; set; }

    public string? CurrCityVillage { get; set; }

    public string? CurrState { get; set; }

    public decimal? CurrPincode { get; set; }

    public string? NewTehsil { get; set; }

    public string? NewDistrict { get; set; }

    public string? NewThana { get; set; }

    public string? NewCityVillage { get; set; }

    public string? NewState { get; set; }

    public decimal? NewPincode { get; set; }

    public string? RequestStatus { get; set; }

    public int IsFinalApproved { get; set; }

    public decimal? SEmpIdA { get; set; }

    public string? RequestType { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal TranId { get; set; }

    public DateTime? ChildBirthDate { get; set; }
}
