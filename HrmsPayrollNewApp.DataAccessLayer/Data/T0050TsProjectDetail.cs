using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050TsProjectDetail
{
    public decimal ProjectDetailId { get; set; }

    public decimal? ProjectId { get; set; }

    public decimal? AssignTo { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? BranchId { get; set; }

    public virtual T0040TsProjectMaster? Project { get; set; }
}
