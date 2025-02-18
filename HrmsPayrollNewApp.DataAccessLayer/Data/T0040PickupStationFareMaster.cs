using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040PickupStationFareMaster
{
    public decimal FareId { get; set; }

    public decimal? PickupId { get; set; }

    public decimal? Fare { get; set; }

    public decimal? Discount { get; set; }

    public decimal? NetFare { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifiedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public virtual T0040PickupStationMaster? Pickup { get; set; }
}
