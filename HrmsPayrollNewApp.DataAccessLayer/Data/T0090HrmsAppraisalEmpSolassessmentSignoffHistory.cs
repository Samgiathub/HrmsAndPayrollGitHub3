using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAppraisalEmpSolassessmentSignoffHistory
{
    public decimal SignoffId { get; set; }

    public decimal FkSolassessmentId { get; set; }

    public decimal SignoffVersion { get; set; }

    public DateTime SignoffDate { get; set; }

    public decimal EmpId { get; set; }

    public virtual T0090HrmsAppraisalEmpSolassessment FkSolassessment { get; set; } = null!;
}
