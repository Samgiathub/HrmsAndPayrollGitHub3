using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SchemeMaster
{
    public decimal SchemeId { get; set; }

    public decimal CmpId { get; set; }

    public string SchemeName { get; set; } = null!;

    public string SchemeType { get; set; } = null!;

    public bool DefaultScheme { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0050SchemeDetail> T0050SchemeDetails { get; set; } = new List<T0050SchemeDetail>();

    public virtual ICollection<T0095EmpScheme> T0095EmpSchemes { get; set; } = new List<T0095EmpScheme>();

    public virtual ICollection<T0095HrmsCandidateScheme> T0095HrmsCandidateSchemes { get; set; } = new List<T0095HrmsCandidateScheme>();

    public virtual ICollection<T0100HrmsCandidateSchemeLevel> T0100HrmsCandidateSchemeLevels { get; set; } = new List<T0100HrmsCandidateSchemeLevel>();
}
