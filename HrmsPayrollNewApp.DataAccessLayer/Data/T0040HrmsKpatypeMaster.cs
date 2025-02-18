using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsKpatypeMaster
{
    public decimal KpaTypeId { get; set; }

    public decimal CmpId { get; set; }

    public string? KpaType { get; set; }

    public virtual ICollection<T0051KpaMaster> T0051KpaMasters { get; set; } = new List<T0051KpaMaster>();

    public virtual ICollection<T0052HrmsKpa> T0052HrmsKpas { get; set; } = new List<T0052HrmsKpa>();

    public virtual ICollection<T0060AppraisalEmployeeKpa> T0060AppraisalEmployeeKpas { get; set; } = new List<T0060AppraisalEmployeeKpa>();
}
