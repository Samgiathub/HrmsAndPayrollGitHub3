using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GetEmpForGrievCommitteeMember
{
    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? BranchName { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal StateId { get; set; }

    public int DistrictId { get; set; }

    public int TehsilId { get; set; }

    public decimal VerticalId { get; set; }

    public decimal SubVertical { get; set; }

    public decimal BusiSgmt { get; set; }
}
