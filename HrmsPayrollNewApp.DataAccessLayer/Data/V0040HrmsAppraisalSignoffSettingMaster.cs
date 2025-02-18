using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040HrmsAppraisalSignoffSettingMaster
{
    public decimal SettingId { get; set; }

    public decimal SettingCmpId { get; set; }

    public decimal SettingEmpId { get; set; }

    public decimal SettingType { get; set; }

    public decimal SettingYear { get; set; }

    public DateTime SettingFromDate { get; set; }

    public DateTime SettingToDate { get; set; }

    public decimal SettingCreatedBy { get; set; }

    public DateTime SettingCreatedDate { get; set; }

    public decimal? SettingModifyBy { get; set; }

    public DateTime? SettingModifyDate { get; set; }

    public string? EmpFullNameNew { get; set; }

    public decimal? BranchId { get; set; }

    public string? BranchName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? DeptId { get; set; }

    public string? DeptName { get; set; }
}
