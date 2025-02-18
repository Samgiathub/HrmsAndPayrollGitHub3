using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050HrmsSkillRateSetting
{
    public decimal SkillDId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? AvgSkillActualRate { get; set; }

    public decimal? AvgSkillRRateMin { get; set; }

    public decimal? AvgSkillRRateMax { get; set; }

    public decimal? SkillEvalDuration { get; set; }

    public DateTime? ForeDate { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0040DepartmentMaster? Dept { get; set; }

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual T0040GradeMaster? Grd { get; set; }

    public virtual ICollection<T0055HrmsSkillRateDetail> T0055HrmsSkillRateDetails { get; set; } = new List<T0055HrmsSkillRateDetail>();
}
