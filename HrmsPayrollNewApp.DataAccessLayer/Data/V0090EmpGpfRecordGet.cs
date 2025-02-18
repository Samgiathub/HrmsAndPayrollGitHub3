using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpGpfRecordGet
{
    public decimal EmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal BasicSalary { get; set; }

    public decimal? GpfOnBasic { get; set; }

    public decimal BranchId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime DateOfJoin { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }
}
