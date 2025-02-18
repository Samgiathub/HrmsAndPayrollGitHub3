using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0001LocationMaster
{
    public decimal LocId { get; set; }

    public string? LocName { get; set; }

    public string? AttTimeDiff { get; set; }

    public decimal? LocCatId { get; set; }

    public virtual ICollection<T0055ResumeMaster> T0055ResumeMasterPermanentLocs { get; set; } = new List<T0055ResumeMaster>();

    public virtual ICollection<T0055ResumeMaster> T0055ResumeMasterPresentLocNavigations { get; set; } = new List<T0055ResumeMaster>();

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();

    public virtual ICollection<T0090EmpImmigrationDetail> T0090EmpImmigrationDetails { get; set; } = new List<T0090EmpImmigrationDetail>();

    public virtual ICollection<T0090HrmsResumeImmigration> T0090HrmsResumeImmigrations { get; set; } = new List<T0090HrmsResumeImmigration>();
}
