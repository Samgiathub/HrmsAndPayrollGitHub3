using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ProjectStatus
{
    public decimal ProjectStatusId { get; set; }

    public string? ProjectStatus { get; set; }

    public string? Remarks { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? Color { get; set; }

    public decimal? StatusType { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0011Login? CreatedByNavigation { get; set; }

    public virtual ICollection<T0040TaskMaster> T0040TaskMasters { get; set; } = new List<T0040TaskMaster>();

    public virtual ICollection<T0040TsProjectMaster> T0040TsProjectMasters { get; set; } = new List<T0040TsProjectMaster>();

    public virtual ICollection<T0100TsApplication> T0100TsApplications { get; set; } = new List<T0100TsApplication>();

    public virtual ICollection<T0120TsApproval> T0120TsApprovals { get; set; } = new List<T0120TsApproval>();
}
