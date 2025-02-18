using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055HrmsEmpSkillDetail
{
    public decimal SkillRId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal LoginId { get; set; }

    public string Status { get; set; } = null!;

    public decimal? SkillActualRate { get; set; }

    public decimal? SkillRateGiven { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0080EmpMaster? SEmp { get; set; }

    public virtual ICollection<T0090HrmsEmpSkillSetting> T0090HrmsEmpSkillSettings { get; set; } = new List<T0090HrmsEmpSkillSetting>();
}
