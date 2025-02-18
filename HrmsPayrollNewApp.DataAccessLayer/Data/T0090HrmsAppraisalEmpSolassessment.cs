using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAppraisalEmpSolassessment
{
    public decimal SolassessmentId { get; set; }

    public decimal SolassessmentCmpId { get; set; }

    public decimal? FkEmployeeId { get; set; }

    public decimal? FkSupervisorId { get; set; }

    public byte? EmployeeSignOff { get; set; }

    public DateTime? EmployeeSignOffDate { get; set; }

    public byte? SupervisorSignOff { get; set; }

    public DateTime? SupervisorSignOffDate { get; set; }

    public DateTime? SolassessmentStartDate { get; set; }

    public DateTime? SolassessmentEndDate { get; set; }

    public decimal? SolassessmentYear { get; set; }

    public decimal SolassessmentCreatedBy { get; set; }

    public DateTime SolassessmentCreatedDate { get; set; }

    public decimal? SolassessmentModifyBy { get; set; }

    public DateTime? SolassessmentModifyDate { get; set; }

    public virtual ICollection<T0090HrmsAppraisalEmpSolassessmentDtl> T0090HrmsAppraisalEmpSolassessmentDtls { get; set; } = new List<T0090HrmsAppraisalEmpSolassessmentDtl>();

    public virtual ICollection<T0090HrmsAppraisalEmpSolassessmentSignoffHistory> T0090HrmsAppraisalEmpSolassessmentSignoffHistories { get; set; } = new List<T0090HrmsAppraisalEmpSolassessmentSignoffHistory>();
}
