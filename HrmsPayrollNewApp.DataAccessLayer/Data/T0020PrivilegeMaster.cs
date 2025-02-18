using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0020PrivilegeMaster
{
    public decimal PrivilegeId { get; set; }

    public decimal CmpId { get; set; }

    public string? PrivilegeName { get; set; }

    public byte? IsActive { get; set; }

    public byte? PrivilegeType { get; set; }

    public decimal? BranchId { get; set; }

    public string? BranchIdMulti { get; set; }

    public string? VerticalIdMulti { get; set; }

    public string? SubVerticalIdMulti { get; set; }

    public string? DepartmentIdMulti { get; set; }

    public string? StateIdMulti { get; set; }

    public string? DistrictIdMulti { get; set; }

    public string? TehsilIdMulti { get; set; }

    public int? OldEffect { get; set; }

    public virtual ICollection<T0050PrivilegeDetail> T0050PrivilegeDetails { get; set; } = new List<T0050PrivilegeDetail>();
}
