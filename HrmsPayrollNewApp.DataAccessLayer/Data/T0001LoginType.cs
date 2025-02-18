using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0001LoginType
{
    public decimal LoginTypeId { get; set; }

    public string LoginType { get; set; } = null!;

    public decimal IsSave { get; set; }

    public decimal IsEdit { get; set; }

    public decimal IsDelete { get; set; }

    public decimal IsReport { get; set; }

    public virtual ICollection<T0015LoginRight> T0015LoginRights { get; set; } = new List<T0015LoginRight>();
}
