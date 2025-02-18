using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsAppraisalSolMaster
{
    public decimal SolId { get; set; }

    public decimal SolCmpId { get; set; }

    public string Sol { get; set; } = null!;

    public byte SolIsActive { get; set; }

    public decimal SolCreatedBy { get; set; }

    public DateTime SolCreatedDate { get; set; }

    public decimal? SolModifyBy { get; set; }

    public DateTime? SolModifyDate { get; set; }

    public virtual ICollection<T0090HrmsAppraisalEmpSolassessmentDtl> T0090HrmsAppraisalEmpSolassessmentDtls { get; set; } = new List<T0090HrmsAppraisalEmpSolassessmentDtl>();
}
