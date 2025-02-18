using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ClientMaster
{
    public decimal ClientId { get; set; }

    public string? ClientName { get; set; }

    public string? ClientAddress { get; set; }

    public string? ContactPerson { get; set; }

    public string? PhoneNo { get; set; }

    public string? MobileNo { get; set; }

    public string? Email { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public virtual ICollection<T0040TsProjectMaster> T0040TsProjectMasters { get; set; } = new List<T0040TsProjectMaster>();
}
