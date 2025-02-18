using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040QualificationMaster
{
    public decimal QualId { get; set; }

    public decimal CmpId { get; set; }

    public string QualName { get; set; } = null!;

    public string? QualType { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0010HrCompReq> T0010HrCompReqs { get; set; } = new List<T0010HrCompReq>();

    public virtual ICollection<T0090EmpQualificationDetail> T0090EmpQualificationDetails { get; set; } = new List<T0090EmpQualificationDetail>();

    public virtual ICollection<T0090HrmsResumeQualification> T0090HrmsResumeQualifications { get; set; } = new List<T0090HrmsResumeQualification>();
}
