using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050HrmsEmpOaFeedback
{
    public decimal EmpOaId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? InitiationId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? OaId { get; set; }

    public string? EoaColumn1 { get; set; }

    public string? EoaColumn2 { get; set; }

    public string? RmComments { get; set; }

    public string? HodComments { get; set; }

    public string? GhComments { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0050HrmsInitiateAppraisal? Initiation { get; set; }

    public virtual T0040HrmsOtherAssessmentMaster? Oa { get; set; }
}
