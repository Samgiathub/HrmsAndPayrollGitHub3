using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SelfAppraisalMaster
{
    public decimal SapparisalId { get; set; }

    public decimal? CmpId { get; set; }

    public string? SapparisalContent { get; set; }

    public int? SappraisalSort { get; set; }

    public string? SdeptId { get; set; }

    public int? SisMandatory { get; set; }

    public int? Stype { get; set; }

    public int? Sweight { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? RefSid { get; set; }

    public decimal? Skpaweight { get; set; }

    public string? ScategId { get; set; }

    public string? SbranchId { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual ICollection<T0050SaSubCriterion> T0050SaSubCriteria { get; set; } = new List<T0050SaSubCriterion>();

    public virtual ICollection<T0052EmpSelfAppraisal> T0052EmpSelfAppraisals { get; set; } = new List<T0052EmpSelfAppraisal>();
}
