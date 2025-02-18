using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrDocMaster
{
    public decimal HrDocId { get; set; }

    public string? DocTitle { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public string? DocContent { get; set; }

    public int? DisplayJoinining { get; set; }

    public string? Gender { get; set; }

    public string? JoinDays { get; set; }

    public int? DisplayEss { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0040DepartmentMaster? Dept { get; set; }

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual T0040GradeMaster? Grd { get; set; }

    public virtual ICollection<T0090EmpHrDocDetail> T0090EmpHrDocDetails { get; set; } = new List<T0090EmpHrDocDetail>();
}
