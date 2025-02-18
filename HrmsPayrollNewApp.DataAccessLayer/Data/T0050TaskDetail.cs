using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050TaskDetail
{
    public decimal TaskDetailId { get; set; }

    public decimal? TaskId { get; set; }

    public decimal? AssignTo { get; set; }

    public decimal? ProjectId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public virtual T0080EmpMaster? AssignToNavigation { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0011Login? CreatedByNavigation { get; set; }

    public virtual T0040TsProjectMaster? Project { get; set; }

    public virtual T0040TaskMaster? Task { get; set; }
}
